import { CityState } from '../model/CityState'

export interface HealthParams {
  totalBudget: number
  monthDays: number
  currentDayIndex: number
  todayExpense: number
  monthExpense: number
}

export class HealthCalculator {
  static calculate(_params: HealthParams): CityState {
    return {
      healthLevel: 1,
      healthName: '繁荣',
      buildingLayer: 'prosperous',
      weatherLayer: 'sunny',
      animationType: 'bird',
      description: '占位健康状态，后续补充真实算法'
    }
  }
}
