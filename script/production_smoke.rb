# Run against a disposable PostgreSQL database in production mode.
require "nokogiri"

browser = ActionDispatch::Integration::Session.new(Rails.application)
browser.host! "localhost"
browser.https!
browser.get "/"
abort "Board failed: #{browser.response.status}" unless browser.response.status == 200
csrf = Nokogiri::HTML(browser.response.body).at_css('meta[name="csrf-token"]')["content"]
marker = "Production smoke #{SecureRandom.hex(8)}"
browser.post "/tasks", params: { authenticity_token: csrf, task: { title: marker, status: "todo", priority: "high" } }
abort "Create failed: #{browser.response.status}" unless browser.response.status == 303
task = Task.find_by!(title: marker)
owner = task.demo_session
browser.get "/tasks/#{task.id}"
abort "Show failed" unless browser.response.status == 200
browser.patch "/tasks/#{task.id}/transition", params: { authenticity_token: csrf, status: "done" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
abort "Turbo failed" unless browser.response.status == 200 && task.reload.status == "done"
browser.post "/demo/reset", params: { authenticity_token: csrf }
abort "Reset failed" unless browser.response.status == 303 && owner.tasks.count == 7
browser.post "/tasks", params: { task: { title: "CSRF must fail" } }
abort "CSRF protection missing" unless browser.response.status == 422
owner.destroy!
puts "Production HTTP/CSRF/CRUD/Turbo/reset smoke passed (PostgreSQL)."
