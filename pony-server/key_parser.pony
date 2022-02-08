use "files"
use "regex"

class val Key
    let secret: String
    let public: String

    new create(secret': String, public': String) =>
        secret = secret'
        public = public'


class KeyParser
    var _secret: String
    var _public: String
    let _printer: Printer

    new create(env: Env, printer': Printer, filename: String) =>
        _secret = ""
        _public = ""
        _printer = printer'

        try
            let relative_path = Path.join(".", filename)
            with file = OpenFile(FilePath(env.root, relative_path)) as File do

                var text: String val =
                      file.read_string(file.size())

                let secret_regex = Regex("secret-key\\s*\\=\\s*\"(?<key>\\S+?)\"")?
                let secret_match = secret_regex(text)?

                _secret = secret_match.find("key")?

                let public_regex = Regex("public-key\\s*\\=\\s*\"(?<key>\\S+?)\"")?
                let public_match = public_regex(text)?

                _public = public_match.find("key")?
            end
        else
            _printer.print("KeyParser: failed to parse " + filename)
        end

    fun key(): Key =>
        recover val Key(_secret,_public) end