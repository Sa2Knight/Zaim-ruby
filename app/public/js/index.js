var index = new Vue({
  el: '#user',
  data: {
    isLoading: true,
    baseinfo: {},
  },
  methods: {
    load() {
      zaim.user((res) => {
        this.isLoading = false;
        this.baseinfo = res.data;
      });
    },
  },
});

index.load();
