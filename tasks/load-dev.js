import { sleep } from"k6";
import http from "k6/http";

export let options = {
  duration: "1m",
  vus: 50,
};

export default function() {
  http.get("http://demo-app.demo-app-dev.svc.cluster.local:8080/");
  sleep(1);
};