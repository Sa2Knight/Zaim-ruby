var user = new Vue({
  el: '#user',
  data: {
    isLoading: true,
    data: {},
  },
  methods: {
    load() {
      axios.get('/api/user')
        .then(res => {
          this.isLoading = false;
          this.data = res.data;
        })
    },
  },
});

user.load();
