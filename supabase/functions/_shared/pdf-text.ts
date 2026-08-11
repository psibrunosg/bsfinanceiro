import { extractText, getDocumentProxy } from "unpdf";

const MAX_BYTES = 10 * 1024 * 1024;
const MAX_PAGES = 20;
const PDF_HEADER = [0x25, 0x50, 0x44, 0x46, 0x2d];
const PDF_ERRORS = new Set(["invalid_pdf", "pdf_too_large", "pdf_too_many_pages", "pdf_without_selectable_text"]);

function fail(code: string): never {
  throw new Error(code);
}

export async function extractSelectablePdfText(bytes: Uint8Array): Promise<{ text: string; totalPages: number }> {
  if (bytes.byteLength > MAX_BYTES) fail("pdf_too_large");
  if (PDF_HEADER.some((value, index) => bytes[index] !== value)) fail("invalid_pdf");

  let document: Awaited<ReturnType<typeof getDocumentProxy>> | undefined;
  let rawText = "";
  try {
    document = await getDocumentProxy(bytes);
    const extracted = await extractText(document, { mergePages: true });
    if (extracted.totalPages > MAX_PAGES) fail("pdf_too_many_pages");
    rawText = extracted.text;
    const text = rawText.replace(/\s+/g, " ").trim();
    if (!text) fail("pdf_without_selectable_text");
    rawText = "";
    return { text, totalPages: extracted.totalPages };
  } catch (error) {
    if (error instanceof Error && PDF_ERRORS.has(error.message)) throw error;
    fail("invalid_pdf");
  } finally {
    rawText = "";
    await document?.cleanup();
    await document?.loadingTask.destroy();
  }
  fail("invalid_pdf");
}
