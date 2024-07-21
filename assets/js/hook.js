let Hooks = {}

Hooks.InputCurrency = {
    mounted() {
        this.el.addEventListener("input", (event) => {
            let value = this.el.value.replace(/\D/g, "");
            value = Number(value).toLocaleString('id-ID');
            this.el.value = value;
          });
    }
}

export default Hooks;