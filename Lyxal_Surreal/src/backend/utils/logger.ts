// =========================================================
// Logger PRO pour LYXAL Surreal Engine
// =========================================================

// Format JSON pour logs cloud / edge
function logStructured(level: string, message: string, meta?: unknown) {
    const timestamp = new Date().toISOString();
  
    const payload = {
      ts: timestamp,
      level,
      message,
      meta,
      source: "Lyxal_Surreal",
    };
  
    console.log(JSON.stringify(payload));
  }
  
  export function logDebug(message: string, meta?: unknown) {
    logStructured("debug", message, meta);
  }
  export function logInfo(message: string, meta?: unknown) {
    logStructured("info", message, meta);
  }
  export function logWarn(message: string, meta?: unknown) {
    logStructured("warn", message, meta);
  }
  export function logError(message: string, meta?: unknown) {
    logStructured("error", message, meta);
  }