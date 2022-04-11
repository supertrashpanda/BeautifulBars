# BeautifulBars
For NISS DataViz Competition 2022

## What we are doing

__The first visulization for pairwise comparison between all degrees is deployed [here](https://supertrashpanda.shinyapps.io/shiny_app/)__. Open to all comments and suggests.

__See the newest dashboard beautified by Jianing [here](https://supertrashpanda.shinyapps.io/Dashboard_Jianing/)__. 

The outstanding issues:
1. 考虑此图用ggplotly()而非ggplot()，但ggplotly()图例混乱，不知如何自定义修正
2. 考虑添加新特性：可更改改货币度量衡，新度量衡Current Dollars
3. 考虑更改文案（描述income gap时是否需要道出哪个学位收入更高）
4. 考虑更改页面布局与美学元素
5. 能否将年限设定为计算平均收入gap的时间范围，与三个输出框挂钩 （已解决）。然后加入一个括号，比总的gap平均要加减多少。（就是让看的人知道近年的收入gap是否缩小或扩大了）
6. 搞一个框，输入预计学费，输出回报年限（以近5年的平均为计算）（以考虑上学的人为对象）
7. 教育与性别图改为图层，可以选择看一个（省空间），或者可以变成差距比较（感觉线很细）

## Acknowledgements
  
* [NISS Visualization Competition Page](https://www.niss.org/events/niss-statistically-accurate-interactive-displays-graphics-0)
