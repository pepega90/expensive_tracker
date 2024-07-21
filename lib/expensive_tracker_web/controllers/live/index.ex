defmodule ExpensiveTrackerWeb.Live.Index do
  use ExpensiveTrackerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Balance Section -->
    <.saldo_component
      total_income={@total_income}
      income_list={@income_list}
      expense_list={@expense_list}
    />
    <!-- Transactions Section -->
    <section class="py-8">
      <div class="container mx-auto max-w-4xl grid grid-cols-1 md:grid-cols-2 gap-8">
        <!-- Income -->
        <.income_component income_list={@income_list} />
        <!-- Expenses -->
        <.expense_component expense_list={@expense_list} />
      </div>
    </section>
    <!-- Add Transaction Section -->
    <section class="py-8 bg-gray-200">
      <div class="container mx-auto max-w-4xl">
        <h3 class="text-2xl font-bold mb-4 text-center">Tambah Transaksi</h3>
        
        <div class="bg-white shadow-md rounded-lg p-8 mx-auto max-w-lg card">
          <!-- Toggle Buttons -->
          <div class="flex justify-center mb-4">
            <button
              phx-click="change_type"
              phx-value-tipe="income"
              id="income-btn"
              class="toggle-btn active-income"
            >
              Pemasukan
            </button>
            
            <button
              phx-click="change_type"
              phx-value-tipe="expense"
              id="expense-btn"
              class="toggle-btn"
            >
              Pengeluaran
            </button>
          </div>
          
          <form phx-submit="add">
            <div class="mb-4">
              <label class="block text-gray-700">Tanggal</label>
              <input type="date" name="date" class="w-full px-4 py-2 border rounded-lg" />
            </div>
            
            <div class="mb-4">
              <label class="block text-gray-700">Keterangan</label>
              <input
                name="desc"
                type="text"
                class="w-full px-4 py-2 border rounded-lg"
                placeholder="Bayar Cicilan"
              />
            </div>
            
            <div class="mb-4">
              <label class="block text-gray-700">Nominal</label>
              <input
                phx-hook="InputCurrency"
                id="price-input"
                name="nominal"
                type="text"
                class="w-full px-4 py-2 border rounded-lg"
                placeholder="-150000"
              />
            </div>
             <input type="hidden" name="type" id="transaction-type" value="income" />
            <button
              type="submit"
              class="w-full gradient-animation text-white px-6 py-2 rounded-lg font-semibold hover:bg-purple-700"
            >
              Tambah
            </button>
          </form>
        </div>
      </div>
    </section>
    """
  end

  defmodule Income do
    defstruct [:id, :tanggal, :desc, :nominal, :type]
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       income_list: [],
       expense_list: [],
       total_income: 0,
       tipe: ""
     )}
  end

  @impl true
  def handle_event("change_type", %{"tipe" => "income"} = _params, socket),
    do: {:noreply, socket |> assign(tipe: "income")}

  def handle_event("change_type", %{"tipe" => "expense"} = _params, socket),
    do: {:noreply, socket |> assign(tipe: "expense")}

  def handle_event("add", %{"date" => "", "desc" => "", "nominal" => ""} = _params, socket),
    do: {:noreply, socket}

  def handle_event(
        "add",
        %{"date" => tgl, "desc" => desc, "nominal" => nominal},
        %{
          assigns: %{
            income_list: income_list,
            expense_list: expense_list,
            tipe: tipe,
            total_income: total_income
          }
        } = socket
      ) do
    case tipe do
      "income" ->
        new_income = %Income{
          id: length(income_list) + 1,
          tanggal: tgl,
          desc: desc,
          nominal: nominal |> String.replace(".", ""),
          type: tipe
        }

        updated_income = [new_income | income_list]

        updated_total =
          updated_income |> Enum.reduce(0, fn e, acc -> String.to_integer(e.nominal) + acc end)

        {:noreply, socket |> assign(income_list: updated_income, total_income: updated_total)}

      "expense" ->
        expense_income = %Income{
          id: length(expense_list) + 1,
          tanggal: tgl,
          desc: desc,
          nominal: nominal |> String.replace(".", ""),
          type: tipe
        }

        update_expense = [expense_income | expense_list]

        updated_total = total_income - String.to_integer(expense_income.nominal)

        {:noreply, socket |> assign(expense_list: update_expense, total_income: updated_total)}
    end
  end

  def handle_event(
        "hapus_income",
        %{"id" => id} = _params,
        %{assigns: %{income_list: income_list}} = socket
      ) do
    updated_income_list = income_list |> Enum.filter(fn e -> e.id != String.to_integer(id) end)

    updated_total =
      updated_income_list |> Enum.reduce(0, fn e, acc -> String.to_integer(e.nominal) + acc end)

    {:noreply, socket |> assign(income_list: updated_income_list, total_income: updated_total)}
  end

  def handle_event(
        "hapus_expense",
        %{"id" => id} = _params,
        %{assigns: %{expense_list: expense_list, total_income: total_income}} = socket
      ) do
    find_expense = expense_list |> Enum.find(fn e -> e.id == String.to_integer(id) end)

    updated_total = total_income + String.to_integer(find_expense.nominal)

    updated_expense = expense_list |> Enum.filter(fn e -> e.id != find_expense.id end)

    {:noreply, socket |> assign(total_income: updated_total, expense_list: updated_expense)}
  end
end
