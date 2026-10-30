import { execFileSync } from 'node:child_process';
import { describe, expect, it } from 'vitest';
describe('card import cent allocation', () => {
  it('uses exactly the same cents for validation and persistence', () => {
    const output = execFileSync('php', ['-r', 'require "server/card-import-routes.php"; echo json_encode([cardImportInstallmentCents(101,3,1),cardImportInstallmentCents(101,3,2),cardImportInstallmentCents(101,3,3)]);'], { encoding: 'utf8' });
    expect(JSON.parse(output)).toEqual([33,33,35]);
    // Source installment 2/3 of 34 cents must fail exact matching before any write.
    expect(JSON.parse(output)[1]).not.toBe(34);
    expect(JSON.parse(output).reduce((sum,value)=>sum+value,0)).toBe(101);
  });
});
