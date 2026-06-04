import { MonthSummary } from '../model/MonthSummary'

export class StatisticService {
  async getMonthSummary(month: string): Promise<MonthSummary> {
    return {
      month,
      totalExpense: 0,
      totalIncome: 0,
      todayExpense: 0,
      remainBudget: 0,
      dailyBudget: 0,
      reasonableTotal: 0,
      healthLevel: 1
    }
  }
}
