const watch = require("node-watch");
const { spawnSync } = require("child_process");

const proceduresPath = "./procedures";

watch(
  proceduresPath,
  {
    recursive: true,
  },
  (eventType, filename) => {
    console.log(eventType, filename);
    switch (eventType) {
      case "update":
        const cmd = `mysql gestionx < ${filename}`;
        const child = spawnSync("sh", ["-c", cmd]);
        console.log(cmd);
        if (child.stdout) console.log(child.stdout.toString());
        if (child.stderr) console.error(child.stderr.toString());
        if (child.error) console.error(child.error);
    }
  }
);
