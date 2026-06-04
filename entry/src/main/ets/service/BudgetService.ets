import { BudgetConfig } from '../model/BudgetConfig'

export class BudgetService {
  async saveBudget(_config: BudgetConfig): Promise<boolean> {
    return true
  }

  async getBudgetByMonth(month: string): Promise<BudgetConfig | null> {
    return {
      month,
      totalBudget: 2000,
      categoryBudgets: {},
      updateTime: ''
    }
  }
}
