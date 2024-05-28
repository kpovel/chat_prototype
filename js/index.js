const form = document.getElementById("form");
const chat = document.getElementById("chat");

function lastMessageId() {
  const lastMessage = chat.lastElementChild;
  return lastMessage.id;
}

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const data = new FormData(e.target);

  const res = await fetch("/message", {
    method: "POST",
    body: `message=${data.get("message")}`,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });

  if (res.status !== 200) {
    return;
  }

  const text = await res.text();
  chat.insertAdjacentHTML("afterbegin", text);
  form.reset();

  chat.scrollBy({ top: chat.scrollHeight, behavior: "smooth" });
});
