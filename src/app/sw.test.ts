import { describe, it, expect, vi, beforeEach } from "vitest";
import fs from "fs";
import path from "path";

describe("Service Worker", () => {
  let addEventListenerSpy: ReturnType<typeof vi.fn>;
  let eventMap: Record<string, (event: unknown) => void> = {};
  
  beforeEach(() => {
    eventMap = {};
    addEventListenerSpy = vi.fn((event, callback) => {
      eventMap[event] = callback;
    });

    const dummyCache = {
      add: vi.fn().mockResolvedValue(undefined),
      put: vi.fn().mockResolvedValue(undefined),
      match: vi.fn().mockResolvedValue(null),
    };

    Object.assign(globalThis, {
      self: {
        addEventListener: addEventListenerSpy,
        skipWaiting: vi.fn(),
        clients: { claim: vi.fn() },
      },
      caches: {
        open: vi.fn().mockResolvedValue(dummyCache),
        keys: vi.fn().mockResolvedValue(["old-cache"]),
        delete: vi.fn().mockResolvedValue(true),
        match: vi.fn().mockResolvedValue(null),
      },
      fetch: vi.fn().mockResolvedValue({
        status: 200,
        type: "basic",
        clone: () => ({})
      })
    });

    // Evaluate the service worker script
    const swCode = fs.readFileSync(path.join(process.cwd(), "public/sw.js"), "utf8");
    
    eval(swCode);
  });

  it("installs and precaches critical routes", async () => {
    const waitUntilSpy = vi.fn();
    const event = { waitUntil: waitUntilSpy };
    
    eventMap["install"](event);
    
    expect(waitUntilSpy).toHaveBeenCalled();
    expect((globalThis as unknown as Record<string, { skipWaiting: () => void }>).self.skipWaiting).toHaveBeenCalled();
  });

  it("activates and deletes old caches", async () => {
    const waitUntilSpy = vi.fn();
    const event = { waitUntil: waitUntilSpy };
    
    eventMap["activate"](event);
    
    expect(waitUntilSpy).toHaveBeenCalled();
    expect((globalThis as unknown as Record<string, { clients: { claim: () => void } }>).self.clients.claim).toHaveBeenCalled();
  });

  it("falls back to cache when network fails on a GET request", async () => {
    const respondWithSpy = vi.fn();
    const event = {
      request: { method: "GET", url: "http://localhost/page", mode: "navigate" },
      respondWith: respondWithSpy
    };
    
    // Make fetch reject (offline mode)
    Object.assign(globalThis, { fetch: vi.fn().mockRejectedValue(new Error("Network failed")) });
    
    // Make caches.match return a fallback response
    const mockResponse = { status: 200, statusText: "Offline Fallback" };
    (globalThis as unknown as Record<string, { match: (req: string) => Promise<unknown> }>).caches.match = vi.fn().mockImplementation((req) => {
      if (req === "/entrar" || req === "/") return Promise.resolve(mockResponse);
      return Promise.resolve(null);
    });

    eventMap["fetch"](event);
    
    // The respondWith gets called with a Promise
    expect(respondWithSpy).toHaveBeenCalled();
    
    const responsePromise = respondWithSpy.mock.calls[0][0];
    const response = await responsePromise;
    
    expect(response).toBe(mockResponse);
    expect((globalThis as unknown as Record<string, (event: unknown) => void>).fetch).toHaveBeenCalledWith(event.request);
  });

  it("handles push event", async () => {
    const wait = vi.fn();
    const show = vi.fn().mockResolvedValue(undefined);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).self.registration = { showNotification: show };
    
    eventMap["push"]({
      waitUntil: wait,
      data: { json: () => ({ title: "T", message: "M", actionUrl: "/" }) }
    });
    
    expect(wait).toHaveBeenCalled();
    expect(show).toHaveBeenCalledWith("T", expect.objectContaining({ body: "M" }));
  });

  it("handles notificationclick", async () => {
    const wait = vi.fn();
    const close = vi.fn();
    const open = vi.fn().mockResolvedValue(undefined);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (globalThis as any).self.clients.openWindow = open;
    
    eventMap["notificationclick"]({
      waitUntil: wait,
      notification: { close, data: "/" }
    });
    
    expect(close).toHaveBeenCalled();
    expect(open).toHaveBeenCalledWith("/");
  });
});
