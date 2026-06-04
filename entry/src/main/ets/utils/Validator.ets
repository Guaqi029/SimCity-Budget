export class Validator {
  static required(value: string): boolean {
    return value.trim().length > 0
  }
}
