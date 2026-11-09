// Qt6 widget gallery for theme screenshots. build: g++ -fPIC gallery.cpp -o $HK_DIR/qt-gallery $(pkg-config --cflags --libs Qt6Widgets)
#include <QApplication>
#include <QMainWindow>
#include <QMenuBar>
#include <QToolBar>
#include <QListWidget>
#include <QSplitter>
#include <QTabWidget>
#include <QPushButton>
#include <QLineEdit>
#include <QComboBox>
#include <QCheckBox>
#include <QRadioButton>
#include <QSlider>
#include <QProgressBar>
#include <QSpinBox>
#include <QGroupBox>
#include <QTreeWidget>
#include <QTextEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QTimer>
#include <QMenu>
#include <QStatusBar>
#include <QLabel>
#include <QToolButton>
#include <QScrollBar>
#include <QTableWidget>
#include <QHeaderView>

int main(int argc, char** argv) {
    QApplication a(argc, argv);
    QString scene = argc > 1 ? argv[1] : "main";
    QMainWindow w; w.setWindowTitle("Documents"); w.resize(960, 640);
    auto* mb = w.menuBar(); auto* fm = mb->addMenu("File"); fm->addAction("New Window"); fm->addAction("Open..."); fm->addSeparator(); auto* dis = fm->addAction("Disabled"); dis->setEnabled(false); auto* ck = fm->addAction("Checked"); ck->setCheckable(true); ck->setChecked(true);
    mb->addMenu("Edit")->addAction("Undo"); mb->addMenu("View")->addAction("Zoom");
    auto* tb = w.addToolBar("main"); tb->addAction("Back"); tb->addAction("Forward"); tb->addSeparator(); auto* tbtn = new QToolButton; tbtn->setText("Share"); tb->addWidget(tbtn);
    auto* split = new QSplitter; w.setCentralWidget(split);
    auto* side = new QListWidget; for (auto s : {"Recents","Shared","Applications","Desktop","Documents","Downloads"}) side->addItem(s); side->setCurrentRow(4); side->setObjectName("sidebar"); side->setMaximumWidth(220); split->addWidget(side);
    auto* tabs = new QTabWidget; split->addWidget(tabs);
    auto* p = new QWidget; auto* g = new QVBoxLayout(p);
    auto* r0 = new QHBoxLayout; auto* open = new QPushButton("Open"); open->setDefault(true); auto* del = new QPushButton("Delete"); auto* dsb = new QPushButton("Disabled"); dsb->setEnabled(false);
    r0->addWidget(new QPushButton("Cancel")); r0->addWidget(open); r0->addWidget(del); r0->addWidget(dsb); r0->addStretch(); g->addLayout(r0);
    auto* r1 = new QHBoxLayout; auto* le = new QLineEdit("Search text"); auto* le2 = new QLineEdit; le2->setPlaceholderText("Search"); le2->setClearButtonEnabled(true); auto* sp = new QSpinBox; auto* cb = new QComboBox; cb->addItems({"Name","Size","Modified"});
    r1->addWidget(le); r1->addWidget(le2); r1->addWidget(sp); r1->addWidget(cb); g->addLayout(r1);
    auto* r2 = new QHBoxLayout; auto* c1 = new QCheckBox("Check"); c1->setChecked(true); r2->addWidget(c1); r2->addWidget(new QCheckBox("Check")); auto* rb = new QRadioButton("Radio A"); rb->setChecked(true); r2->addWidget(rb); r2->addWidget(new QRadioButton("Radio B")); r2->addStretch(); g->addLayout(r2);
    auto* r3 = new QHBoxLayout; auto* sl = new QSlider(Qt::Horizontal); sl->setValue(40); auto* pb = new QProgressBar; pb->setValue(60); r3->addWidget(sl); r3->addWidget(pb); g->addLayout(r3);
    auto* gb = new QGroupBox("Group box"); auto* gl = new QVBoxLayout(gb); gl->addWidget(new QLabel("Label inside a group")); g->addWidget(gb);
    auto* tree = new QTreeWidget; tree->setHeaderLabels({"Name", "Kind", "Size"}); for (auto n : {"Report.pdf","Budget.xlsx","Photos"}) { auto* it = new QTreeWidgetItem(tree, {n, "Document", "12 KB"}); } tree->setCurrentItem(tree->topLevelItem(1)); g->addWidget(tree);
    auto* te = new QTextEdit; te->setPlainText("Hello world\nQt text edit"); te->setMaximumHeight(60); g->addWidget(te);
    tabs->addTab(p, "General"); tabs->addTab(new QLabel("Second page"), "Advanced");
    w.statusBar()->showMessage("Ready");
    w.show();
    if (scene == "menu") QTimer::singleShot(1200, [&]{ fm->popup(w.mapToGlobal(QPoint(10, 30))); });
    if (scene == "combo") QTimer::singleShot(1200, [&]{ cb->showPopup(); });
    return a.exec();
}
