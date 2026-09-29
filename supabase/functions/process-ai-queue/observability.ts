export function logEvent(event: string, fields: Record<string, unknown> = {}): void {
  console.info(JSON.stringify({
    service: "thinknest",
    event,
    at: new Date().toISOString(),
    ...fields,
  }));
}

export function logError(event: string, fields: Record<string, unknown> = {}): void {
  console.error(JSON.stringify({
    service: "thinknest",
    event,
    at: new Date().toISOString(),
    ...fields,
  }));
}
