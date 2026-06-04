export class MoneyUtil {
  static format(value: number): string {
    return `¥${value.toFixed(2)}`
  }
}
