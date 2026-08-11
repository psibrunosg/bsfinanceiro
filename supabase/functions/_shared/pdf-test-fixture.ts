const encoder = new TextEncoder();

function pdfString(value: string) {
  return value.replace(/[\\()]/g, "\\$&");
}

function buildPdf(pageTexts: string[]) {
  const pageObjectStart = 3;
  const contentObjectStart = pageObjectStart + pageTexts.length;
  const fontObject = contentObjectStart + pageTexts.length;
  const objects = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    `<< /Type /Pages /Kids [${pageTexts.map((_, index) => `${pageObjectStart + index} 0 R`).join(" ")}] /Count ${pageTexts.length} >>`,
    ...pageTexts.map((_, index) => `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 ${fontObject} 0 R >> >> /Contents ${contentObjectStart + index} 0 R >>`),
    ...pageTexts.map((text) => {
      const stream = `BT /F1 12 Tf 72 720 Td (${pdfString(text)}) Tj ET`;
      return `<< /Length ${encoder.encode(stream).length} >>\nstream\n${stream}\nendstream`;
    }),
    "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
  ];
  let pdf = "%PDF-1.4\n";
  const offsets = [0];
  for (let index = 0; index < objects.length; index += 1) {
    offsets.push(encoder.encode(pdf).length);
    pdf += `${index + 1} 0 obj\n${objects[index]}\nendobj\n`;
  }
  const xrefOffset = encoder.encode(pdf).length;
  pdf += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
  pdf += offsets.slice(1).map((offset) => `${String(offset).padStart(10, "0")} 00000 n \n`).join("");
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefOffset}\n%%EOF`;
  return encoder.encode(pdf);
}

export const textualPdf = () => buildPdf(["Fatura   Santander\n  Agosto 2026"]);
export const blankPdf = () => buildPdf([""]);
export const multiPagePdf = (pages: number) => buildPdf(Array.from({ length: pages }, () => "pagina"));
