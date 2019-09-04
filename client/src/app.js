let app = (a,x) => a['div.container'](
  [
    a.h1( 'Hello World' ),
    a.p( [
      a.i( { class: 'fas fa-globe' } ),
      'So far, so good.'
    ] ),
  ],
  {
    $init: () => systemLoadingSpinner.style.display = 'none'
  }
)
