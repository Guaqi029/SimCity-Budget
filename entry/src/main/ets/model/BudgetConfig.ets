export interface BudgetConfig {
  month: string
  totalBudget: number
  categoryBudgets: Record<string, number>
  updateTime: string
}
