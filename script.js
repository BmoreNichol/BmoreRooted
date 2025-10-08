// Mobile Navigation Toggle
const hamburger = document.getElementById('hamburger');
const navLinks = document.getElementById('navLinks');

hamburger.addEventListener('click', () => {
    navLinks.classList.toggle('active');
});

// Close mobile menu when clicking a link
navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
        navLinks.classList.remove('active');
    });
});

// Form Submission Handler
const contactForm = document.getElementById('contactForm');

if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        e.preventDefault();

        // Collect form data
        const formData = new FormData(contactForm);
        const data = Object.fromEntries(formData);

        // Here you would typically send the data to a server
        console.log('Form submitted:', data);

        // Show success message
        alert('Thank you for your inquiry! We will contact you shortly.');

        // Reset form
        contactForm.reset();
    });
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Sticky CTA Button - Show/Hide on Scroll
const stickyCta = document.getElementById('stickyCta');

if (stickyCta) {
    window.addEventListener('scroll', () => {
        if (window.scrollY > 300) {
            stickyCta.classList.add('show');
        } else {
            stickyCta.classList.remove('show');
        }
    });

    // Track sticky CTA clicks
    stickyCta.addEventListener('click', () => {
        if (typeof gtag !== 'undefined') {
            gtag('event', 'click', {
                'event_category': 'CTA',
                'event_label': 'Sticky CTA Button',
                'value': 1
            });
        }
    });
}

// FAQ Accordion Functionality
document.querySelectorAll('.faq-question').forEach(question => {
    question.addEventListener('click', () => {
        const answer = question.nextElementSibling;
        const isActive = question.classList.contains('active');

        // Close all other FAQ items
        document.querySelectorAll('.faq-question').forEach(q => {
            if (q !== question) {
                q.classList.remove('active');
                q.nextElementSibling.classList.remove('active');
            }
        });

        // Toggle current FAQ item
        if (!isActive) {
            question.classList.add('active');
            answer.classList.add('active');
        } else {
            question.classList.remove('active');
            answer.classList.remove('active');
        }
    });
});

// Enhanced Google Analytics Event Tracking
function trackEvent(category, action, label) {
    if (typeof gtag !== 'undefined') {
        gtag('event', action, {
            'event_category': category,
            'event_label': label
        });
    }
}

// Track all CTA button clicks
document.querySelectorAll('.cta-button, .cta-button-large').forEach(button => {
    button.addEventListener('click', (e) => {
        const buttonText = button.textContent.trim();
        trackEvent('CTA', 'click', buttonText);
    });
});

// Track service card clicks
document.querySelectorAll('.service-card').forEach(card => {
    card.addEventListener('click', (e) => {
        const serviceName = card.querySelector('h4')?.textContent.trim() || 'Unknown Service';
        trackEvent('Service', 'click', serviceName);
    });
});

// Track phone number clicks
document.querySelectorAll('a[href^="tel:"]').forEach(link => {
    link.addEventListener('click', () => {
        const phoneNumber = link.getAttribute('href').replace('tel:', '');
        trackEvent('Contact', 'phone_click', phoneNumber);
    });
});

// Track email link clicks
document.querySelectorAll('a[href^="mailto:"]').forEach(link => {
    link.addEventListener('click', () => {
        const email = link.getAttribute('href').replace('mailto:', '');
        trackEvent('Contact', 'email_click', email);
    });
});

// Track social media link clicks
document.querySelectorAll('.social-links a').forEach(link => {
    link.addEventListener('click', () => {
        const platform = link.textContent.trim();
        trackEvent('Social', 'click', platform);
    });
});

// Track external link clicks
document.querySelectorAll('a[target="_blank"]').forEach(link => {
    link.addEventListener('click', () => {
        const url = link.getAttribute('href');
        trackEvent('External', 'click', url);
    });
});

// Enhanced Form Submission with Netlify Forms and GA tracking
if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        const formData = new FormData(contactForm);
        const serviceType = formData.get('service');

        // Track form submission
        trackEvent('Form', 'submit', `Contact Form - ${serviceType}`);

        // Note: With Netlify Forms, the default form submission will be handled by Netlify
        // The form will submit naturally without e.preventDefault() for Netlify to process it
    });
}

// 404 Page Search Functionality
const searchInput = document.getElementById('searchServices');
if (searchInput) {
    searchInput.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        const serviceLinks = document.querySelectorAll('.services-list a');

        serviceLinks.forEach(link => {
            const serviceName = link.textContent.toLowerCase();
            if (serviceName.includes(searchTerm)) {
                link.style.display = 'block';
            } else {
                link.style.display = 'none';
            }
        });
    });
}
