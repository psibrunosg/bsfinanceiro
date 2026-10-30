// @vitest-environment jsdom
import { cleanup, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, expect, it, vi } from "vitest";
const mocks=vi.hoisted(()=>({fetch:vi.fn(),token:"abc123"}));
vi.mock("@/lib/api-client",()=>({apiFetch:mocks.fetch}));
vi.mock("next/navigation",()=>({useSearchParams:()=>new URLSearchParams(`token=${mocks.token}`)}));
vi.mock("@/lib/app-path",()=>({appPath:(path:string)=>path}));
import InvitePage from "./page";
afterEach(()=>cleanup());
beforeEach(()=>{mocks.fetch.mockReset(); localStorage.clear();sessionStorage.clear();Object.defineProperty(window,"location",{value:{replace:vi.fn()},writable:true});});
it("keeps pending invite for login when VPS session expires",async()=>{
 mocks.fetch.mockResolvedValue({status:401,ok:false});render(<InvitePage/>);
 await waitFor(()=>expect(window.location.replace).toHaveBeenCalledWith("/entrar"));
 expect(sessionStorage.getItem("pending_invite_token")).toBe("abc123");
});
it("activates only the workspace returned by the VPS",async()=>{
 mocks.fetch.mockResolvedValue({status:200,ok:true,json:async()=>({success:true,workspace:{id:"authorized-workspace"}})});render(<InvitePage/>);
 await waitFor(()=>expect(window.location.replace).toHaveBeenCalledWith("/"));
 expect(JSON.parse(localStorage.getItem("bsfinanceiro_workspace")!)).toEqual({id:"authorized-workspace"});
});
it("shows server rejection without activating a workspace",async()=>{
 mocks.fetch.mockResolvedValue({status:404,ok:false,json:async()=>({error:"Convite inválido ou expirado."})});render(<InvitePage/>);
 await waitFor(()=>expect(screen.getByRole("status").textContent).toContain("expirado"));
 expect(localStorage.getItem("bsfinanceiro_workspace")).toBeNull();
});
