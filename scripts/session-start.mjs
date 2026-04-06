#!/usr/bin/env node

/**
 * oh-my-worxphere SessionStart hook
 *
 * 1. Checks if omc plugin is installed (dependency)
 * 2. Detects missing MCP configurations
 * 3. Caches health status (24h TTL) to avoid repeated checks
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import { homedir } from 'node:os';

const configDir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), '.claude');
const dataDir = process.env.CLAUDE_PLUGIN_DATA || join(configDir, 'plugins', 'data', 'oh-my-worxphere');
const SETTINGS_PATH = join(configDir, 'settings.json');
const INSTALLED_PLUGINS_PATH = join(configDir, 'plugins', 'installed_plugins.json');
const HEALTH_CACHE_PATH = join(dataDir, 'health.json');
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

const REQUIRED_MCPS = ['slack', 'github'];
const RECOMMENDED_MCPS = ['notion', 'gitlab', 'context7'];

function readJson(path) {
  try {
    if (!existsSync(path)) return null;
    return JSON.parse(readFileSync(path, 'utf-8'));
  } catch {
    return null;
  }
}

function writeJson(path, data) {
  try {
    const dir = join(path, '..');
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    writeFileSync(path, JSON.stringify(data, null, 2));
  } catch {
    // Silent fail — cache is optional
  }
}

function getCachedHealth() {
  const cached = readJson(HEALTH_CACHE_PATH);
  if (!cached || !cached.timestamp) return null;
  if (Date.now() - cached.timestamp > CACHE_TTL_MS) return null;
  return cached;
}

function checkOmcInstalled() {
  try {
    const data = readJson(INSTALLED_PLUGINS_PATH);
    if (!data) return false;
    const plugins = data.plugins || {};
    return Object.keys(plugins).some((key) => key.startsWith('oh-my-claudecode@'));
  } catch {
    return false;
  }
}

function checkMcpStatus() {
  const settings = readJson(SETTINGS_PATH);
  if (!settings) {
    return { configured: [], missing: [...REQUIRED_MCPS, ...RECOMMENDED_MCPS] };
  }

  const servers = settings.mcpServers || {};
  const configured = [];
  const missing = [];

  for (const name of [...REQUIRED_MCPS, ...RECOMMENDED_MCPS]) {
    if (servers[name]) {
      configured.push(name);
    } else {
      missing.push(name);
    }
  }

  return { configured, missing };
}

function runHealthCheck() {
  const omcInstalled = checkOmcInstalled();
  const { configured, missing } = checkMcpStatus();
  const missingRequired = missing.filter((m) => REQUIRED_MCPS.includes(m));
  const missingRecommended = missing.filter((m) => RECOMMENDED_MCPS.includes(m));

  const issues = [];

  if (!omcInstalled) {
    issues.push('omc plugin missing');
  }
  if (missingRequired.length > 0) {
    issues.push(`required MCP missing: ${missingRequired.join(', ')}`);
  }

  const result = {
    timestamp: Date.now(),
    omcInstalled,
    mcpConfigured: configured,
    mcpMissing: missing,
    missingRequired,
    missingRecommended,
    issueCount: issues.length + missingRecommended.length,
    issues,
  };

  // Cache result
  writeJson(HEALTH_CACHE_PATH, result);

  return result;
}

function main() {
  // Try cache first
  const cached = getCachedHealth();
  const health = cached || runHealthCheck();

  const parts = [];

  if (!health.omcInstalled) {
    parts.push(
      '[Worxphere] omc plugin not found. Run: claude plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode && claude plugin install oh-my-claudecode@omc'
    );
  }

  if (health.missingRequired && health.missingRequired.length > 0) {
    parts.push(
      `[Worxphere] Missing required MCP: ${health.missingRequired.join(', ')}. Run /worx-mcp-config`
    );
  }

  if (health.issueCount > 0) {
    parts.push(
      `[Worxphere] ${health.issueCount} issue(s) found. Run /worx-doctor for details.`
    );
  }

  if (parts.length > 0) {
    console.log(parts.join(' | '));
  }
}

main();
