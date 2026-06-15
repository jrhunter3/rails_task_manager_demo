// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

// Prevent Turbo from replacing page content with error text on navigation failure,
// which could end up inside a focused Trix editor.
document.addEventListener("turbo:error", (event) => {
  event.preventDefault()
})
