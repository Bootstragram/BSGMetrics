project_name = "BSGMetrics"
project_version = "DEVELOP"
project_company = "Bootstragram"
company_id = "com.bootstragram"

desc "Open"
task :open do |t|
  sh "cd Example && bundle exec pod install && open \"BSGMetrics.xcworkspace\""
end

desc "Generate the documentation"
task :appledoc do |t|
  sh "/usr/local/bin/appledoc --verbose 2 --output ./doc --ignore Pods --ignore .m --project-name #{project_name} --project-version #{project_version} --keep-undocumented-objects --keep-undocumented-members --project-company #{project_company} --company-id #{company_id} --no-repeat-first-par --no-create-docset --create-html --index-desc README.md BSGMetrics/Classes"
end

desc "Update pods"
task :pod_update => [ :pod_repo_update ] do |t|
  sh "bundle exec pod update --project-directory=Example"
end

desc "Update pods repo"
task :pod_repo_update do |t|
  sh "bundle exec pod repo update"
end
