actor Printer
  let _env : Env

  new create(env: Env) =>
    _env = env

  be print(message: String) =>
    _env.out.print(message)
