import { describe, expect, it } from "vitest";

import { parseMoney } from "./Money";

const NBSP = String.fromCharCode(0x00a0);

describe("parseMoney", () => {
  it("aceita o formato pt-BR com milhar e decimal", () => {
    expect(parseMoney("1.234,56")).toBe(1234.56);
    expect(parseMoney("1234,56")).toBe(1234.56);
    expect(parseMoney("1.234.567,89")).toBe(1234567.89);
    expect(parseMoney("0,50")).toBe(0.5);
  });

  it("aceita ponto como separador decimal", () => {
    expect(parseMoney("1234.56")).toBe(1234.56);
    expect(parseMoney("1234.5")).toBe(1234.5);
  });

  it("trata pontos como milhar quando nao ha decimal de 1 ou 2 digitos", () => {
    expect(parseMoney("1.234")).toBe(1234);
    expect(parseMoney("1.234.567")).toBe(1234567);
  });

  it("aceita inteiros simples", () => {
    expect(parseMoney("50")).toBe(50);
    expect(parseMoney("0")).toBe(0);
  });

  it("ignora simbolos de moeda, espacos e espacos nao separaveis", () => {
    expect(parseMoney("R$ 1.234,56")).toBe(1234.56);
    expect(parseMoney(`R$${NBSP}1.234,56`)).toBe(1234.56);
    expect(parseMoney(`1${NBSP}234,56`)).toBe(1234.56);
    expect(parseMoney("  1.234,56  ")).toBe(1234.56);
  });

  it("aceita sinal negativo", () => {
    expect(parseMoney("-100,00")).toBe(-100);
    expect(parseMoney("-R$ 1.234,56")).toBe(-1234.56);
    expect(parseMoney("-0,50")).toBe(-0.5);
  });

  it("retorna 0 para entradas vazias, nulas ou nao numericas", () => {
    expect(parseMoney("")).toBe(0);
    expect(parseMoney(null)).toBe(0);
    expect(parseMoney("abc")).toBe(0);
    expect(parseMoney("R$")).toBe(0);
    expect(parseMoney("   ")).toBe(0);
  });

  it("nunca retorna NaN", () => {
    const entradas = ["", "abc", "R$ ", "--", ",", ".", "-", null];
    for (const entrada of entradas) {
      expect(Number.isNaN(parseMoney(entrada))).toBe(false);
    }
  });

  it("arredonda para 2 casas decimais", () => {
    expect(parseMoney("0,1")).toBe(0.1);
    expect(parseMoney("1234,567")).toBe(1234.57);
  });
});
