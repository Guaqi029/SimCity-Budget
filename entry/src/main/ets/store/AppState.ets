export interface DashboardStats {
  todayExpense: string
  monthExpense: string
  remainBudget: string
  healthName: string
}

export class AppState {
  currentTab: number = 0
  stats: DashboardStats = {
    todayExpense: '¥53.00',
    monthExpense: '¥388.00',
    remainBudget: '¥1612.00',
    healthName: '繁荣'
  }
}
