export interface CategoryBudget {
  categoryId: string
  categoryName: string
  amount: number
}

export interface MonthlyBudget {
  month: string
  totalBudget: number
  categoryBudgets: CategoryBudget[]
  createTime: string
  updateTime: string
}

