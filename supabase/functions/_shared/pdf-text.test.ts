import { afterEach, expect, test, vi } from "vitest";
import { blankPdf, multiPagePdf, textualPdf } from "./pdf-test-fixture";

type Extractor = (bytes: Uint8Array) => Promise<{ text: string; totalPages: number }>;

async function extractor(): Promise<Extractor> {
  const module = await import("./pdf-text").catch(() => null);
  expect(module).not.toBeNull();
  return module!.extractSelectablePdfText;
}

async function expectPdfError(bytes: Uint8Array, code: string) {
  try {
    await (await extractor())(bytes);
    throw new Error("expected PDF extraction to fail");
  } catch (error) {
    expect(error).toBeInstanceOf(Error);
    expect((error as Error).message).toBe(code);
  }
}

async function mockExtractor({
  pages,
  text = "texto",
  cleanup = vi.fn().mockResolvedValue(undefined),
  destroy = vi.fn().mockResolvedValue(undefined),
}: {
  pages: number;
  text?: string;
  cleanup?: ReturnType<typeof vi.fn>;
  destroy?: ReturnType<typeof vi.fn>;
}) {
  const extractText = vi.fn().mockResolvedValue({ totalPages: pages, text });
  vi.doMock("unpdf", () => ({
    extractText,
    getDocumentProxy: vi.fn().mockResolvedValue({ numPages: pages, cleanup, loadingTask: { destroy } }),
  }));
  await vi.resetModules();
  const module = await import("./pdf-text");
  return { extractText, extract: module.extractSelectablePdfText };
}

afterEach(async () => {
  vi.doUnmock("unpdf");
  await vi.resetModules();
});

test("extracts normalized selectable text from a real one-page PDF", async () => {
  await expect((await extractor())(textualPdf())).resolves.toEqual({
    text: "Fatura Santander\nAgosto 2026",
    totalPages: 1,
  });
});

test("preserves line boundaries while normalizing selectable text", async () => {
  const { extract } = await mockExtractor({ pages: 1, text: "EMPREGADOR: ACME\n  COMPETÊNCIA: 07/2026" });
  await expect(extract(textualPdf())).resolves.toEqual({ text: "EMPREGADOR: ACME\nCOMPETÊNCIA: 07/2026", totalPages: 1 });
});

test("rejects bytes without a PDF header", async () => {
  await expectPdfError(new TextEncoder().encode("not a PDF"), "invalid_pdf");
});

test("rejects a PDF over 10 MiB before parsing", async () => {
  const bytes = new Uint8Array(10 * 1024 * 1024 + 1);
  bytes.set(textualPdf());
  await expectPdfError(bytes, "pdf_too_large");
});

test("rejects PDFs with more than 20 pages", async () => {
  await expectPdfError(multiPagePdf(21), "pdf_too_many_pages");
});

test("rejects too many pages before starting text extraction", async () => {
  const { extract, extractText } = await mockExtractor({ pages: 21 });
  await expect(extract(textualPdf())).rejects.toThrow("pdf_too_many_pages");
  expect(extractText).not.toHaveBeenCalled();
});

test("rejects PDFs without selectable text", async () => {
  await expectPdfError(blankPdf(), "pdf_without_selectable_text");
});

test("preserves a successful result when cleanup and destroy reject", async () => {
  const { extract } = await mockExtractor({
    pages: 1,
    cleanup: vi.fn().mockRejectedValue(new Error("cleanup failed")),
    destroy: vi.fn().mockRejectedValue(new Error("destroy failed")),
  });
  await expect(extract(textualPdf())).resolves.toEqual({ text: "texto", totalPages: 1 });
});

test("preserves the primary PDF error when cleanup and destroy reject", async () => {
  const { extract } = await mockExtractor({
    pages: 21,
    cleanup: vi.fn().mockRejectedValue(new Error("cleanup failed")),
    destroy: vi.fn().mockRejectedValue(new Error("destroy failed")),
  });
  await expect(extract(textualPdf())).rejects.toThrow("pdf_too_many_pages");
});
