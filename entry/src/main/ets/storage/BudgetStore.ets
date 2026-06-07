import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { CategoryBudget, MonthlyBudget } from '../model/Budget'

const BUDGET_STORE_NAME: string = 'budget_store'
const BUDGET_LIST_KEY: string = 'monthly_budget_list'

export class BudgetStore {
  static load(context: common.Context): Promise<MonthlyBudget[]> {
    return preferences.getPreferences(context, BUDGET_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return store.get(BUDGET_LIST_KEY, '[]')
      })
      .then((value: preferences.ValueType) => {
        if (typeof value !== 'string') {
          return []
        }
        const budgets = JSON.parse(value) as MonthlyBudget[]
        if (!Array.isArray(budgets)) {
          return []
        }
        return budgets.map((budget: MonthlyBudget) => BudgetStore.normalize(budget))
      })
      .catch(() => {
        return []
      })
  }

  static save(context: common.Context, budgets: MonthlyBudget[]): Promise<void> {
    return preferences.getPreferences(context, BUDGET_STORE_NAME)
      .then((store: preferences.Preferences) => {
        store.put(BUDGET_LIST_KEY, JSON.stringify(budgets))
        return store.flush()
      })
  }

  static findByMonth(budgets: MonthlyBudget[], month: string): MonthlyBudget {
    for (let index = 0; index < budgets.length; index++) {
      if (budgets[index].month === month) {
        return budgets[index]
      }
    }
    const now = new Date().toISOString()
    return {
      month: month,
      totalBudget: 0,
      categoryBudgets: [],
      createTime: now,
      updateTime: now
    }
  }

  static upsert(budgets: MonthlyBudget[], budget: MonthlyBudget): MonthlyBudget[] {
    const nextBudgets: MonthlyBudget[] = []
    let replaced = false
    for (let index = 0; index < budgets.length; index++) {
      if (budgets[index].month === budget.month) {
        nextBudgets.push(budget)
        replaced = true
      } else {
        nextBudgets.push(budgets[index])
      }
    }
    if (!replaced) {
      nextBudgets.push(budget)
    }
    return nextBudgets
  }

  private static normalize(budget: MonthlyBudget): MonthlyBudget {
    const now = new Date().toISOString()
    const totalBudget = Number(budget.totalBudget)
    return {
      month: budget.month,
      totalBudget: totalBudget === totalBudget ? totalBudget : 0,
      categoryBudgets: BudgetStore.normalizeCategoryBudgets(budget.categoryBudgets),
      createTime: budget.createTime === undefined ? now : budget.createTime,
      updateTime: budget.updateTime === undefined ? now : budget.updateTime
    }
  }

  private static normalizeCategoryBudgets(categoryBudgets: CategoryBudget[]): CategoryBudget[] {
    if (categoryBudgets === undefined || !Array.isArray(categoryBudgets)) {
      return []
    }
    const result: CategoryBudget[] = []
    for (let index = 0; index < categoryBudgets.length; index++) {
      const amount = Number(categoryBudgets[index].amount)
      result.push({
        categoryId: categoryBudgets[index].categoryId,
        categoryName: categoryBudgets[index].categoryName,
        amount: amount === amount ? amount : 0
      })
    }
    return result
  }
}

