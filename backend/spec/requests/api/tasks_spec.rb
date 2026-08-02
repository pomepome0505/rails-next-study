require "rails_helper"

RSpec.describe "タスクAPI", type: :request do
  def response_json
    JSON.parse(response.body)
  end

  describe "GET /api/tasks" do
    context "タスクが存在する場合" do
      it "タスク一覧を新しい順に返す" do
        older = create(
          :task, title: "古いタスク", description: "古い説明",
          status: :todo, due_date: Date.new(2026, 7, 20), created_at: 2.days.ago
        )
        newer = create(
          :task, title: "新しいタスク", description: "新しい説明",
          status: :done, due_date: Date.new(2026, 7, 30), created_at: 1.day.ago
        )

        get "/api/tasks"

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "data" => [
            {
              "id" => newer.id,
              "title" => "新しいタスク",
              "description" => "新しい説明",
              "status" => "done",
              "due_date" => "2026-07-30",
              "user_id" => newer.user_id,
              "created_at" => String,
              "updated_at" => String
            },
            {
              "id" => older.id,
              "title" => "古いタスク",
              "description" => "古い説明",
              "status" => "todo",
              "due_date" => "2026-07-20",
              "user_id" => older.user_id,
              "created_at" => String,
              "updated_at" => String
            }
          ],
          "meta" => {
            "current_page" => 1,
            "per_page" => 10,
            "total_pages" => 1,
            "total_count" => 2,
            "next_page" => nil,
            "prev_page" => nil
          }
        )
      end
    end

    context "絞り込み・並び替え・ページングを同時に指定した場合" do
      it "条件を満たすタスクを指定順・指定ページで返す" do
        create(:task, status: :done, due_date: Date.new(2026, 7, 1))
        create(:task, status: :todo, due_date: Date.new(2026, 7, 10))
        create(:task, status: :todo, due_date: Date.new(2026, 7, 20))
        latest = create(:task, status: :todo, due_date: Date.new(2026, 7, 30))

        get "/api/tasks", params: {
          status: "todo", sort_by: "due_date", order: "asc", page: 2, per_page: 2
        }

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "data" => [ a_hash_including("id" => latest.id) ],
          "meta" => {
            "current_page" => 2, "per_page" => 2, "total_pages" => 2,
            "total_count" => 3, "next_page" => nil, "prev_page" => 1
          }
        )
      end
    end

    context "タスクが存在しない場合" do
      it "空のdataと0件のmetaを返す" do
        get "/api/tasks"

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "data" => [],
          "meta" => {
            "current_page" => 1, "per_page" => 10, "total_pages" => 0,
            "total_count" => 0, "next_page" => nil, "prev_page" => nil
          }
        )
      end
    end

    context "statusを指定した場合" do
      it "指定したstatusのタスクだけを取得できる" do
        todo_task = create(:task, status: :todo)
        create(:task, status: :done)

        get "/api/tasks", params: { status: "todo" }

        expect(response).to have_http_status(:ok)
        expect(response_json["data"].map { |task| task["id"] }).to eq([ todo_task.id ])
      end
    end

    context "sort_byにdue_date、orderにascを指定した場合" do
      it "due_dateの昇順でタスクを取得できる" do
        earlier_task = create(:task, due_date: Date.new(2026, 7, 20))
        later_task = create(:task, due_date: Date.new(2026, 7, 30))

        get "/api/tasks", params: { sort_by: "due_date", order: "asc" }

        expect(response).to have_http_status(:ok)
        expect(response_json["data"].map { |task| task["id"] }).to eq([ earlier_task.id, later_task.id ])
      end
    end

    context "sort_byにdue_date、orderにdescを指定した場合" do
      it "due_dateの降順でタスクを取得できる" do
        later_task = create(:task, due_date: Date.new(2026, 7, 30))
        earlier_task = create(:task, due_date: Date.new(2026, 7, 20))

        get "/api/tasks", params: { sort_by: "due_date", order: "desc" }

        expect(response).to have_http_status(:ok)
        expect(response_json["data"].map { |task| task["id"] }).to eq([ later_task.id, earlier_task.id ])
      end
    end

    context "pageとper_pageを指定した場合" do
      it "指定したページのタスクを返す" do
        create_list(:task, 3)

        get "/api/tasks", params: { page: 2, per_page: 2 }

        expect(response).to have_http_status(:ok)
        expect(response_json["data"].size).to eq(1)
        expect(response_json["meta"]).to include("current_page" => 2, "per_page" => 2)
      end
    end

    context "不正なstatusを指定した場合" do
      it "400 Bad Requestを返す" do
        get "/api/tasks", params: { status: "invalid_status" }

        expect(response).to have_http_status(:bad_request)
        expect(response_json).to match(
          "message" => "Invalid status",
          "errors" => [],
          "request_id" => String
        )
      end
    end

    context "不正なsort_byを指定した場合" do
      it "400 Bad Requestを返す" do
        get "/api/tasks", params: { sort_by: "invalid_column", order: "asc" }

        expect(response).to have_http_status(:bad_request)
        expect(response_json).to match(
          "message" => "Invalid sort_by",
          "errors" => [],
          "request_id" => String
        )
      end
    end

    context "不正なpageを指定した場合" do
      it "400 Bad Requestを返す" do
        get "/api/tasks", params: { page: 0 }

        expect(response).to have_http_status(:bad_request)
        expect(response_json).to match(
          "message" => "Invalid page",
          "errors" => [],
          "request_id" => String
        )
      end
    end
  end

  describe "GET /api/tasks/:id" do
    context "指定したタスクが存在する場合" do
      it "タスク詳細を取得できる" do
        task = create(
          :task,
          title: "詳細取得の確認",
          description: "詳細説明",
          status: :todo,
          due_date: Date.new(2026, 7, 20)
        )

        get "/api/tasks/#{task.id}"

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "id" => task.id,
          "title" => "詳細取得の確認",
          "description" => "詳細説明",
          "status" => "todo",
          "due_date" => "2026-07-20",
          "user_id" => task.user_id,
          "created_at" => String,
          "updated_at" => String
        )
      end
    end

    context "指定したタスクが存在しない場合" do
      it "404 Not Foundを返す" do
        get "/api/tasks/999999"

        expect(response).to have_http_status(:not_found)
        expect(response_json).to match(
          "message" => "Resource not found",
          "errors" => [],
          "request_id" => String
        )
      end
    end
  end

  describe "POST /api/tasks" do
    context "有効なパラメータの場合" do
      it "タスクを作成できる" do
        user = create(:user)
        params = {
          task: {
            title: "作成の確認",
            description: "作成できることを確認する",
            status: "todo",
            due_date: "2026-07-20",
            user_id: user.id
          }
        }

        expect {
          post "/api/tasks", params: params, as: :json
        }.to change(Task, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response_json).to match(
          "id" => Task.last.id,
          "title" => "作成の確認",
          "description" => "作成できることを確認する",
          "status" => "todo",
          "due_date" => "2026-07-20",
          "user_id" => user.id,
          "created_at" => String,
          "updated_at" => String
        )
      end
    end

    context "titleが空の場合" do
      it "422 Unprocessable Entityを返し、タスクを作成しない" do
        user = create(:user)
        params = {
          task: {
            title: "",
            description: "タイトルなし",
            status: "todo",
            due_date: "2026-07-20",
            user_id: user.id
          }
        }

        expect {
          post "/api/tasks", params: params, as: :json
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_json).to match(
          "message" => "Validation failed",
          "errors" => contain_exactly(
            { "field" => "title", "code" => "blank", "message" => String, "full_message" => String }
          ),
          "request_id" => String
        )
      end
    end

    context "user_idが指定されていない場合" do
      it "422 Unprocessable Entityを返し、タスクを作成しない" do
        params = {
          task: {
            title: "ユーザーなしのタスク",
            status: "todo"
          }
        }

        expect {
          post "/api/tasks", params: params, as: :json
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_json).to match(
          "message" => "Validation failed",
          "errors" => contain_exactly(
            { "field" => "user", "code" => "blank", "message" => String, "full_message" => String }
          ),
          "request_id" => String
        )
      end
    end
  end

  describe "PATCH /api/tasks/:id" do
    context "有効なパラメータの場合" do
      it "タスクを更新できる" do
        task = create(
          :task,
          title: "更新前のタイトル",
          description: "更新前の説明",
          status: :todo,
          due_date: Date.new(2026, 7, 20)
        )

        params = {
          task: {
            title: "更新後のタイトル",
            description: "更新後の説明",
            status: "done",
            due_date: "2026-07-30"
          }
        }

        patch "/api/tasks/#{task.id}", params: params, as: :json

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "id" => task.id,
          "title" => "更新後のタイトル",
          "description" => "更新後の説明",
          "status" => "done",
          "due_date" => "2026-07-30",
          "user_id" => task.user_id,
          "created_at" => String,
          "updated_at" => String
        )
      end
    end

    context "一部のフィールドだけ指定した場合" do
      it "指定していないフィールドは変更しない" do
        task = create(
          :task,
          title: "更新前のタイトル",
          description: "変わらない説明",
          status: :todo,
          due_date: Date.new(2026, 7, 20)
        )

        patch "/api/tasks/#{task.id}", params: { task: { title: "更新後のタイトル" } }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "id" => task.id,
          "title" => "更新後のタイトル",
          "description" => "変わらない説明",
          "status" => "todo",
          "due_date" => "2026-07-20",
          "user_id" => task.user_id,
          "created_at" => String,
          "updated_at" => String
        )
      end
    end

    context "titleが空の場合" do
      it "422 Unprocessable Entityを返し、タスクを更新しない" do
        task = create(
          :task,
          title: "更新前のタイトル",
          status: :todo
        )

        params = {
          task: {
            title: ""
          }
        }

        patch "/api/tasks/#{task.id}", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_json).to match(
          "message" => "Validation failed",
          "errors" => contain_exactly(
            { "field" => "title", "code" => "blank", "message" => String, "full_message" => String }
          ),
          "request_id" => String
        )
        expect(task.reload.title).to eq("更新前のタイトル")
      end
    end

    context "指定したタスクが存在しない場合" do
      it "404 Not Foundを返す" do
        params = {
          task: {
            title: "存在しないタスクの更新"
          }
        }

        patch "/api/tasks/999999", params: params, as: :json

        expect(response).to have_http_status(:not_found)
        expect(response_json).to match(
          "message" => "Resource not found",
          "errors" => [],
          "request_id" => String
        )
      end
    end
  end

  describe "DELETE /api/tasks/:id" do
    context "指定したタスクが存在する場合" do
      it "タスクを削除できる" do
        task = create(
          :task,
          title: "削除対象のタスク",
          status: :todo
        )

        expect {
          delete "/api/tasks/#{task.id}"
        }.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_blank
      end
    end

    context "指定したタスクが存在しない場合" do
      it "404 Not Foundを返し、タスク数は変わらない" do
        expect {
          delete "/api/tasks/999999"
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:not_found)
        expect(response_json).to match(
          "message" => "Resource not found",
          "errors" => [],
          "request_id" => String
        )
      end
    end
  end
end
