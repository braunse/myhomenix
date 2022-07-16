name:
let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  locked = lock.nodes.${name}.locked;
  outPath =
    if locked.type == "github"
    then
      fetchTarball
        {
          url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
          sha256 = locked.narHash;
        }
    else
      throw "Unsupported type ${locked.type}";
in
locked // {
  inherit outPath;
}
