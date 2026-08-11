import { expect, test } from "vitest";
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

test("extracts normalized selectable text from a real one-page PDF", async () => {
  await expect((await extractor())(textualPdf())).resolves.toEqual({
    text: "Fatura Santander Agosto 2026",
    totalPages: 1,
  });
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

test("rejects PDFs without selectable text", async () => {
  await expectPdfError(blankPdf(), "pdf_without_selectable_text");
});
