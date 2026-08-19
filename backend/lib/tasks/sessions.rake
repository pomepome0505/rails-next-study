namespace :sessions do
  desc "期限切れセッションを削除する"
  task cleanup: :environment do
    count = Session.expired.count
    Session.expired.in_batches.delete_all
    puts "Deleted #{count} expired sessions."
  end
end
