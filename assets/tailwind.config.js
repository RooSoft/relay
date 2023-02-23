// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    fontFamily: {
      data: ["Martian Mono", "monospace"],
    },
    extend: {
      backgroundColor: theme => ({
        'primary': '#1A2238',
        'header': '#253150',
        'secondary': '#b48658',
      }),
      textColor: theme => ({
        'primary': '#b9b9c2de',
        'header': '#b9b9c2de',
        'secondary': '#b48658',
        'funds': '#0D9488',
        'debt': '#BE123C'
      }),
      colors: {
        brand: "#FD4F00",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
}