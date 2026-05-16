String? validateSearchInput(String? value) {
  if (value == null || value.isEmpty) {
    return 'Search field cannot be empty';
  }
  if (value.length < 3) {
    return 'Enter at least 3 characters';
  }
  return null;
}
