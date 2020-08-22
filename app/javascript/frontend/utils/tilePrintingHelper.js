export function determineValue(value) {
  if (value == 10) {
    return 'Plus';
  } else if (value == 11) {
    return 'Times';
  } else if (value == 12) {
    return 'Minus';
  } else if (value == 13) {
    return 'Over';
  }

  return value;
}
