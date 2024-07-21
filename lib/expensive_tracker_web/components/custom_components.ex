defmodule ExpensiveTrackerWeb.CustomComponents do
  import Number.Currency

  use Phoenix.Component

  attr :total_income, :integer, default: 0
  attr :income_list, :list, default: []
  attr :expense_list, :list, default: []

  def saldo_component(assigns) do
    ~H"""
    <section class="py-8">
      <div class="container mx-auto max-w-4xl">
        <div class="bg-white shadow-md rounded-lg p-8 text-center card">
          <h2 class="text-3xl font-bold mb-4">Saldo</h2>
          
          <p class="text-4xl font-semibold text-gray-900 mb-4">
            <%= @total_income
            |> number_to_currency(unit: "Rp", precision: 0, delimiter: ".", separator: ",") %>
          </p>
          
          <div class="flex justify-around mt-4">
            <div>
              <p class="text-xl text-gray-600">Total Pemasukan</p>
              
              <p class="text-2xl font-semibold text-green-500">
                <%= @income_list
                |> Enum.map(fn e -> e.nominal |> String.to_integer() end)
                |> Enum.sum()
                |> number_to_currency(unit: "Rp", precision: 0, delimiter: ".", separator: ",") %>
              </p>
            </div>
            
            <div>
              <p class="text-xl text-gray-600">Total Pengeluaran</p>
              
              <p class="text-2xl font-semibold text-red-500">
                <%= @expense_list
                |> Enum.map(fn e -> e.nominal |> String.to_integer() end)
                |> Enum.sum()
                |> number_to_currency(unit: "Rp", precision: 0, delimiter: ".", separator: ",") %>
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :income_list, :list, default: []

  def income_component(assigns) do
    ~H"""
    <div>
      <h3 class="text-2xl font-bold mb-4 text-center">Pemasukan</h3>
      
      <div class="bg-white shadow-md rounded-lg p-6 card">
        <ul>
          <%= if Enum.empty?(@income_list) do %>
            <li class="py-2 text-center text-gray-500">Tidak ada pemasukan.</li>
          <% else %>
            <%= for income <- @income_list |> Enum.filter(fn e -> e.type == "income" end) do %>
              <li class="border-b border-gray-200 py-2">
                <div class="flex justify-between items-center">
                  <div>
                    <span><%= income.desc %></span>
                    <div class="text-sm text-gray-500"><%= income.tanggal |> format_date %></div>
                  </div>
                  
                  <div>
                    <span class="text-green-500">
                      <%= income.nominal
                      |> number_to_currency(
                        unit: "Rp",
                        precision: 0,
                        delimiter: ".",
                        separator: ","
                      ) %>
                    </span>
                    
                    <button
                      phx-click="hapus_income"
                      phx-value-id={income.id}
                      class="text-red-500 ml-4"
                    >
                      Hapus
                    </button>
                  </div>
                </div>
              </li>
            <% end %>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  attr :expense_list, :list, default: []

  def expense_component(assigns) do
    ~H"""
    <div>
      <h3 class="text-2xl font-bold mb-4 text-center">Pengeluaran</h3>
      
      <div class="bg-white shadow-md rounded-lg p-6 card">
        <ul>
          <%= if Enum.empty?(@expense_list) do %>
            <li class="py-2 text-center text-gray-500">Tidak ada pengeluaran.</li>
          <% else %>
            <%= for expense <- @expense_list |> Enum.filter(fn e -> e.type == "expense" end) do %>
              <li class="border-b border-gray-200 py-2">
                <div class="flex justify-between items-center">
                  <div>
                    <span><%= expense.desc %></span>
                    <div class="text-sm text-gray-500"><%= expense.tanggal |> format_date %></div>
                  </div>
                  
                  <div>
                    <span class="text-red-500">
                      <%= expense.nominal
                      |> number_to_currency(
                        unit: "Rp",
                        precision: 0,
                        delimiter: ".",
                        separator: ","
                      ) %>
                    </span>
                    
                    <button
                      phx-click="hapus_expense"
                      phx-value-id={expense.id}
                      class="text-red-500 ml-4"
                    >
                      Hapus
                    </button>
                  </div>
                </div>
              </li>
            <% end %>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp format_date(date_string) do
    date_string
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
    |> NaiveDateTime.to_date()
    |> Timex.format!("{D} {Mfull} {YYYY}")
  end
end
