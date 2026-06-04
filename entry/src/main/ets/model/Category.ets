export interface Category {
  id: string
  name: string
  icon: string
  budget?: number
}

export const DEFAULT_CATEGORIES: Category[] = [
  { id: 'food', name: '餐饮', icon: '🍽️', budget: 800 },
  { id: 'entertainment', name: '娱乐', icon: '🎮', budget: 300 },
  { id: 'study', name: '学习', icon: '📚', budget: 300 },
  { id: 'daily', name: '日用', icon: '🧴', budget: 400 },
  { id: 'traffic', name: '交通', icon: '🚌', budget: 200 },
  { id: 'clothes', name: '服饰', icon: '👕', budget: 0 },
  { id: 'medical', name: '医疗', icon: '💊', budget: 0 },
  { id: 'other', name: '其他', icon: '✨', budget: 0 }
]
