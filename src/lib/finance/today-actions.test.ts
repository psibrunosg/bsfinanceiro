import { describe, expect, it } from "vitest";
import { todayActions } from "./today-actions";

describe("todayActions", () => {
  it("keeps four actions and routes the goal action for zero, one, or many goals", () => {
    expect(todayActions([])).toHaveLength(4);
    expect(todayActions([])[3]).toMatchObject({ label: "Criar meta", href: "/planejamento?focus=new-goal" });
    expect(todayActions([{ id: "goal 1" }])[3]).toMatchObject({ label: "Aportar meta", href: "/planejamento?focus=goal-contribution&goalId=goal%201" });
    expect(todayActions([{ id: "a" }, { id: "b" }])[3]).toMatchObject({ label: "Escolher meta", href: "/planejamento?focus=choose-goal" });
  });
});
