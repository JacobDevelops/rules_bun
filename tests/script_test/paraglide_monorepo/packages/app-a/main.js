import * as messages from "@workspace/i18n/messages";
import { setLocale } from "@workspace/i18n/runtime";

setLocale("sv");

const app = document.querySelector("#app");
if (app) {
    app.textContent = `${messages.hero()} :: ${messages.hello()}`;
}
