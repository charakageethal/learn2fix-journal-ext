#include<stdio.h>

int classify(float a,float b,float c)
{
	if(a<0 || b<0 || c<0)
	{
		return 4;
	}

	if(a<=c-b || b<=a-c || c<=b-a)
	{
		return 4;
	}

	if(a==b && b==c)
	{
		return 1;
	}

	if(a==b || b==c || c==a)
	{
		return 2;
	}

	return 3;
}

int main()
{
	float a,b,c;

	scanf("%f %f %f",&a,&b,&c);
	printf("%d",classify(a,b,c));
	return 0;
}
