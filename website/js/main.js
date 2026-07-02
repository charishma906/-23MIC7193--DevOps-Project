// ABC Technologies - simple client-side interactivity

document.addEventListener('DOMContentLoaded', () => {
  // Highlight active nav link
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('nav a').forEach(a => {
    if (a.getAttribute('href') === path) a.classList.add('active');
  });

  // Contact form (demo only - no backend)
  const form = document.getElementById('contact-form');
  if (form) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const msg = document.getElementById('form-msg');
      msg.textContent = 'Thank you! Your message has been received.';
      msg.style.color = '#157347';
      form.reset();
    });
  }

  // Health badge - confirms the page (and container) is serving correctly
  const badge = document.getElementById('health-badge');
  if (badge) {
    badge.textContent = 'Site Status: UP';
  }
});
