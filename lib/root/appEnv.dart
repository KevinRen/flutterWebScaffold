enum Env {
  dev,
  qa,
  uat,
  product
}

class AppEnv {
  static Env env = Env.dev;
}