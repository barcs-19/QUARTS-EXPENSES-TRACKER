class DatabaseConstant {
  static final String TABLE_ACCOUNT = "account";
  static final String COLUMN_ACCOUNT_USERNAME = "email";
  static final String COLUMN_ACCOUNT_PASSWORD = "password";

  static final String TABLE_RESOURCES = "resources";
  static final String COLUMN_RESOURCES_TYPE = "title";
  static final String COLUMN_RESOURCES_BALANCE = "balance";

  static final String TABLE_CRAVINGS = "cravings";
  static final String COLUMN_CRAVINGS_TITLE = "title";
  static final String COLUMN_CRAVINGS_LOCATION = "location";
  static final String COLUMN_CRAVINGS_AMOUNT = "amount";

  static final String TABLE_EXPENSES = "expenses";
  static final String COLUMN_EXPENSES_TITLE = "title";
  static final String COLUMN_EXPENSES_LOCATION = "location";
  static final String COLUMN_EXPENSES_AMOUNT = "amount";
  static final String COLUMN_EXPENSES_DATE = "date";
}
