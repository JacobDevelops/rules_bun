import * as messages from "@workspace/i18n/messages";

const app = document.querySelector("#app");
if (app) {
    app.textContent = `${messages.hero({ locale: "en" })} :: ${messages.hello({ locale: "en" })}`;
}
