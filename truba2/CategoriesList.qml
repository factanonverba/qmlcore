Item {
	id: categoriesList;
	signal genreChoosed;
	property bool active: true;
	property string prevGenre: "";
	property int count: categoriesListView.count;
	width: active ? renderer.width / 4.2 : 80;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

	ListView {
		id: categoriesListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		model: categoriesModel;
		delegate: CategoryDelegate { }

		onCurrentIndexChanged: { categoriesList.updateContent() }
	}

	Image {
		anchors.centerIn: parent;
		source: colorTheme.res + "more.png";
		visible: !categoriesList.active;
	}

	Timer {
		id: updateTimer;
		property int requestIndex: 0;
		interval: 1000;
		repeat: false;

		onTriggered: {
			if (this.requestIndex != categoriesListView.currentIndex)
				this.restart()

			categoriesList.genreChoosed(categoriesListView.model.get(categoriesListView.currentIndex).list)
			categoriesList.prevGenre = categoriesListView.model.get(categoriesListView.currentIndex).text
		}
	}

	updateContent: {
		updateTimer.requestIndex = categoriesListView.currentIndex
		updateTimer.restart()
	}

	onActiveFocusChanged: {
		var genre = categoriesListView.model.get(categoriesListView.currentIndex).text
		if (this.activeFocus && genre != this.prevGenre)
			this.updateContent()
	}
}