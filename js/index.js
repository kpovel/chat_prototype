const form = document.getElementById("form");
const chat = document.getElementById("chat");

function lastMessageId() {
  const lastMessage = chat.lastElementChild;
  return lastMessage.id;
}

function isScrolledToTop() {
  return -chat.scrollTop === chat.scrollHeight - chat.clientHeight;
}

chat.addEventListener("scroll", async (_) => {
  if (isScrolledToTop()) {
    const res = await fetch(`/message-pagination?id=${lastMessageId()}`);
    if (res.status !== 200) {
      return;
    }

    const text = await res.text();
    chat.insertAdjacentHTML("beforeend", text);
  }
});

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
