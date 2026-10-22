(function () {
  "use strict";

  var config = window.PHP2SHELL_CONFIG || {};
  var form = document.getElementById("scope-form");
  var status = document.getElementById("form-status");
  var year = document.getElementById("year");

  if (year) {
    year.textContent = String(new Date().getFullYear());
  }

  function setStatus(message, type) {
    if (!status) return;
    status.textContent = message;
    if (type) {
      status.setAttribute("data-type", type);
    } else {
      status.removeAttribute("data-type");
    }
  }

  function mailtoLink(subject, body) {
    if (!config.contactEmail) return "";
    return "mailto:" + config.contactEmail +
      "?subject=" + encodeURIComponent(subject) +
      "&body=" + encodeURIComponent(body);
  }

  // Booking links: use a scheduler when configured, otherwise scroll to the form.
  var bookingLinks = document.querySelectorAll("[data-booking]");
  for (var i = 0; i < bookingLinks.length; i += 1) {
    var link = bookingLinks[i];
    if (config.bookingUrl) {
      link.setAttribute("href", config.bookingUrl);
      link.setAttribute("target", "_blank");
      link.setAttribute("rel", "noopener");
    } else {
      link.setAttribute("href", "#contact");
      link.removeAttribute("target");
      link.removeAttribute("rel");
    }
  }

  // Contact email links.
  var emailLinks = document.querySelectorAll("[data-contact-email]");
  for (var j = 0; j < emailLinks.length; j += 1) {
    var emailLink = emailLinks[j];
    if (config.contactEmail) {
      emailLink.textContent = config.contactEmail;
      emailLink.setAttribute("href", mailtoLink("PHP patch verification enquiry", "Hello,\n\nWe would like to discuss PHP patch verification.\n\nCompany:\nPHP hosts:\nTimeline:\n\nThank you."));
    } else {
      emailLink.textContent = "Contact channel being configured";
      emailLink.setAttribute("href", "#contact");
    }
  }

  if (!form) return;

  form.addEventListener("submit", function (event) {
    event.preventDefault();

    if (typeof form.reportValidity === "function" && !form.reportValidity()) {
      return;
    }

    var data;
    try {
      data = Object.fromEntries(new FormData(form).entries());
    } catch (error) {
      setStatus("This browser cannot submit the form. Please use the email link instead.", "error");
      return;
    }

    if (data.consent !== "yes") {
      setStatus("Please confirm that you are authorised to request this work.", "error");
      return;
    }

    var subject = "PHP patch verification request — " + (data.company || "New enquiry");
    var body = [
      "Name: " + (data.name || ""),
      "Work email: " + (data.email || ""),
      "Company: " + (data.company || ""),
      "Website: " + (data.website || "—"),
      "PHP hosts: " + (data.hosts || "—"),
      "Timeline: " + (data.timeline || "—"),
      "",
      "Context:",
      data.message || "—",
      "",
      "Consent: confirmed authorised to request this work; no testing without written scope."
    ].join("\n");

    if (config.formEndpoint) {
      setStatus("Sending your request…", "info");
      fetch(config.formEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: JSON.stringify({
          subject: subject,
          name: data.name || "",
          email: data.email || "",
          company: data.company || "",
          website: data.website || "",
          hosts: data.hosts || "",
          timeline: data.timeline || "",
          message: data.message || "",
          consent: data.consent === "yes",
          body: body
        })
      }).then(function (response) {
        if (!response.ok) throw new Error("HTTP " + response.status);
        form.reset();
        setStatus("Thanks — your request was sent. We will reply within one business day.", "success");
      }).catch(function () {
        setStatus("The form could not send. Please use the email link instead.", "error");
      });
      return;
    }

    var mailto = mailtoLink(subject, body);
    if (mailto) {
      window.location.href = mailto;
      setStatus("Your email app should open with the request prefilled. If it does not, use the email link on this page.", "info");
      return;
    }

    setStatus("The contact channel is not configured yet. Please use the GitHub repository link in the footer.", "error");
  });
})();
